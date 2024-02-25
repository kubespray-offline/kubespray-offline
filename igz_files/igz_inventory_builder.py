import os
import yaml
import argparse
from jinja2 import Environment, FileSystemLoader, meta, Undefined


class SysConfigProcessor:
    """
    SysConfigProcessor is a class designed to process a given Iguazio system configuration file
    containing information about application and data cluster nodes. It extracts
    information from the configuration file and generates an INI file suitable for use
    with Ansible playbooks (Kubespray).

    Initialization:
        SysConfigProcessor(yaml_file: str)

    Properties:
        - nodes: List of application cluster nodes with their IP addresses and roles.
        - etcd_control_plane: List of the first three application cluster nodes, or the first one if fewer than three are available.
        - data_nodes: List of data cluster nodes with their IP addresses.
        - vip: A dictionary containing information about the virtual IP address of the API server, if it exists.

    Methods:
        - get_nodes(): Reads a list of application cluster nodes from the YAML file and populates the 'nodes' property.
        - get_data_nodes(): Reads a list of data cluster nodes from the YAML file and populates the 'data_nodes' property.
        - generate_inventory(template_file: str = "igz_inventory.ini.j2", output_file: str = "igz_inventory.ini"): Generates an INI file using a Jinja2 template, populated with the extracted node and cluster information.
        - generate_overrides(template_file: str = "igz_override.yml.j2", output_file: str = "igz_override.yml"): Generates an INI file using a Jinja2 template, populated with the extracted node and cluster information.

    Example usage:
        processor = SysConfigProcessor("config.yaml")
        processor.get_nodes()
        processor.get_data_nodes()
        processor.generate_inventory()
    """

    def __init__(self, yaml_file):
        self.yaml_file = yaml_file
        self.nodes = []
        self.etcd_control_plane = []
        self.data_nodes = []
        self.vip = {}
        self.username = ''
        self.password = ''
        self.system_id = ''
        self.domain = ''
        self.data_vip = ''
        self.distro = ''

        with open(self.yaml_file, 'r') as file:
            self.config = yaml.safe_load(file)

        self.get_nodes()
        self.get_data_nodes()
        self.get_vip()
        self.get_data_vip()
        self.get_id()
        self.get_domain()

    def get_nodes(self):
        """
        Reads a list of application cluster nodes from the YAML file and populates
        the 'nodes' property. Each node entry contains IP addresses and roles of
        its interfaces. It also populates the 'etcd_control_plane' property with
        the first three nodes, or the first one if fewer than three are available.
        """
        nodes = self.config.get('spec', {}).get('app_cluster', {}).get('nodes', [])
        client_interface_names = []

        for node in nodes:
            roles = node.get('roles', [])
            if 'master' in roles or 'node' in roles:
                mgmt_ip_address = None
                client_ip_address = None
                external_ip_address = None

                interfaces = node.get('interfaces', [])
                for interface in interfaces:
                    if 'mgmt' in interface.get('roles', []):
                        mgmt_ip_address = interface.get('ip_address').split('/', 1)[0]
                    if 'client' in interface.get('roles', []):
                        client_ip_address = interface.get('ip_address').split('/', 1)[0]
                        external_ip_address = interface.get('external_ip_address', None)
                        if external_ip_address is not None:
                            external_ip_address = external_ip_address.split('/', 1)[0]
                        client_interface_names.append(interface.get('name'))

                self.nodes.append({'mgmt_ip_address': mgmt_ip_address, 'client_ip_address': client_ip_address,
                                   'external_ip_address': external_ip_address})

        if len(self.nodes) >= 3:
            self.etcd_control_plane = self.nodes[:3]
        elif self.nodes:
            self.etcd_control_plane = [self.nodes[0]]

    def get_data_nodes(self):
        """
        Reads a list of data cluster nodes from the YAML file and populates the
        'data_nodes' property. Each node entry contains only the IP address.
        """
        data_nodes = self.config.get('spec', {}).get('data_cluster', {}).get('nodes', [])
        for node in data_nodes:
            interfaces = node.get('interfaces', [])
            for interface in interfaces:
                if 'client' in interface.get('roles', []):
                    ip_address = interface.get('ip_address').split('/', 1)[0]
                    self.data_nodes.append(ip_address)
                    break

    def get_id(self):
        system_id = self.config.get('meta', {}).get('id', {})
        if system_id:
            self.system_id = system_id

    def get_domain(self):
        domain = self.config.get('spec', {}).get('domain', {})
        if domain:
            self.domain = domain

    def get_vip(self):
        """
        Checks if the 'spec.app_cluster.apiserver_vip' key exists in the YAML file.
        If it exists, stores the corresponding dictionary as the 'vip' property.
        """
        vip = self.config.get('spec', {}).get('app_cluster', {}).get('apiserver_vip', {})
        if vip:
            self.vip = vip

    def get_data_vip(self):
        """
        Checks if the 'spec.data_cluster.dashboard_vip' key exists in the YAML file.
        If it exists, stores the corresponding value as the 'data_vip' property.
        """
        vip = self.config.get('spec', {}).get('data_cluster', {}).get('dashboard_vip', {})
        if vip:
            self.data_vip = vip

    def generate_inventory(self, template_file="./igz_inventory.ini.j2", output_file="igz_inventory.ini"):
        """
        Generates an INI file using a Jinja2 template, populated with the extracted
        node and cluster information. The INI file is saved to the current directory.

        Args:
            template_file (str): Path to the Jinja2 template file. Default is "igz_inventory.ini.j2".
            output_file (str): Path to the output INI file. Default is "igz_inventory.ini".
        """
        template = SysConfigProcessor._get_template_file(template_file)

        app_nodes = self.nodes
        data_nodes = self.data_nodes
        username = self.username
        password = self.password

        # Render the template with the new variable
        rendered_template = template.render(app_nodes=app_nodes, data_nodes=data_nodes,
                                            username=username,
                                            password=password)

        SysConfigProcessor._write_template(output_file, rendered_template)

    def generate_overrides(self, template_file="./igz_override.yml.j2", output_file="igz_override.yml"):
        """
        Generates YAML file using a Jinja2 template, populated with the extracted
        node and cluster information. The YAML file is saved to the current directory.

        Args:
           template_file (str): Path to the Jinja2 template file. Default is "igz_override.yml.j2".
           output_file (str): Path to the output YAML file. Default is "igz_override.yml".
        """

        class PreserveUndefined(Undefined):
            def __str__(self):
                return "{{" + self._undefined_name + "}}"

        template = SysConfigProcessor._get_template_file(template_file)

        igz_registry_host = self.data_nodes[0] if not self.data_vip else self.data_vip
        igz_registry_port = 8009
        kubespray_nginx_port = 18080
        external_ips = [node['external_ip_address'] for node in self.nodes if node['external_ip_address']]
        if self.vip:
            external_ips.append(self.vip['ip_address'])
            api_endpoint = ':'.join([str(self.vip['ip_address']), str(self.vip['port'])])
        else:
            api_endpoint = ':'.join([str(self.nodes[0]['client_ip']), '6443'])
        supplementary_addresses_in_ssl_keys = ','.join(external_ips)
        system_fqdn = '.'.join([self.system_id, self.domain])
        distro = self.distro

        rendered_template = template.render(supplementary_addresses_in_ssl_keys=supplementary_addresses_in_ssl_keys,
                                            apiserver_vip=self.vip,
                                            system_fqdn=system_fqdn,
                                            igz_registry_host=igz_registry_host,
                                            igz_registry_port=igz_registry_port,
                                            kubespray_nginx_port=kubespray_nginx_port,
                                            distro=distro, api_endpoint=api_endpoint)

        SysConfigProcessor._write_template(output_file, rendered_template)

    @staticmethod
    def _get_template_file(f):
        class PreserveUndefined(Undefined):
            def __str__(self):
                return "{{" + self._undefined_name + "}}"
        env = Environment(loader=FileSystemLoader(os.path.dirname(f)), trim_blocks=True, lstrip_blocks=True,
                          undefined=PreserveUndefined)
        return env.get_template(os.path.basename(f))

    @staticmethod
    def _write_template(f, template):
        with open(f, "w") as file:
            file.write(template)


def _parse_cli():
    parser = argparse.ArgumentParser()
    parser.add_argument('system_config')
    parser.add_argument('user')
    parser.add_argument('password')
    parser.add_argument('distro')
    return parser.parse_args()


def main_flow():
    """
    Reads the arguments from CLI and generates the required files from the templates
    """
    args = _parse_cli()
    system_config = args.system_config
    username = args.user
    password = args.password
    distro = args.distro
    config_processor = SysConfigProcessor(system_config)
    config_processor.username = username
    config_processor.password = password
    config_processor.distro = distro
    config_processor.generate_inventory()
    config_processor.generate_overrides()


if __name__ == "__main__":
    main_flow()
