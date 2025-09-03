# ChangeLogs

## develop

## v2.28.1-0 - 2025/09/03

- Update kubespray 2.28.1

## v2.28.0-0 - 2025/05/24

- Update kubespray 2.28.0
- Fix offline.yml to add 'v' version prefix in download URLs for kubespray 2.28
- Add some download URLs including cilium (#22)
- Update Nginx to 1.28.0
- Update registry server to 2.8.3

## v2.27.0-0 - 2025/01/12

- Update kubespray to 2.27.0
- Update nginx: 1.25.2 -> 1.27.3
- Minor bug fixes

## v2.26.0-0 - 2024/09/11

- Update kubespray to 2.26.0
- Add lacked ruamel.yaml package for inventory builder

## v2.25.0-0 - 2024/05/21

- Update kubespray to 2.25.0
- Add initial support of Ubuntu 24.04
- Update Python to 3.11 or later for Kubespray 2.25 and Ansible 9.5
- Add PPA for latest Python on Ubuntu 20.04
- Mirror binary packages of Ansible
- Remove unused development packages
- Add venv.sh in target-scripts

## v2.24.1-1 - 2024/04/17

- Fix: Use podman to download container images (#36)

## v2.24.1-0 - 2024/04/12

- Update kubespray to 2.24.1
- Fix downloading older container images using nerdctl (#35)

## v2.24.0-0 - 2024/01/20

- Update kubespray to 2.24.0

## v2.23.1-0 - 2024/01/04

- Update kubespray to 2.23.1
- Add RHEL9/AlmaLinux9 support (#28)
- Fix http_server config in README.md (#29)

## v2.23.0-0 - 2023/09/09

- Update kubespray to 2.23.0 (#24)
- Drop support of RHEL/CentOS 7 (#25)
- Change containerd_registries_mirrors configuration (#27) 
- Update python >=3.9 for ansible 7
- Update nginx 1.23 -> 1.25.2
- Update registry 2.8.1 -> 2.8.2

## V2.22.1-0 - 2023/08/25

- Update kubespray to 2.22.1 (#17)

## v2.21.0-1 - 2023/06/19

- Support RHEL 9 (#20)
- Fix: lack of before calling scripts/select-python.sh (#19)
- Fix: handle error when patch dir is empty (#18) 

## v2.21.0-0 - 2023/02/07

- Update kubespray to 2.21.0 (#14)

## v2.20.0-1 - 2022/10/30

- Fix local nginx port number (#12)

## v2.20.0-0 - 2022/10/02

- Update kubespray to 2.20.0 (#10)

## v2.19.1-1 - 2022/10/02

- Add support of Ubuntu 22.04 (#9)

## v2.19.1-0 - 2022/09/04

- BREAKING CHANGE: `runc_download_url` is changed to include runc version in path.
- Update kubespray to 2.19.1.
- Update nginx 1.19 -> 1.23

## v2.19.0-0 - 2022/07/06

- Update kubespray to 2.19.0.
- Install python 3.8 from SCL on RHEL/CentOS 7.

## v2.18.1-1 - 2022/05/28

- Fix: Add selinux python3 packages in prepare-pkgs.sh (#4)
- Fix: Add flit_core for build dependency of pyparsing (#6) 

## v2.18.1-0 - 2022/03/26

- Update kubespray 2.18.1.

## v2.18.0-2 - 2022/03/06

- Runs nginx and local registries using host network mode. (#3)
- Add #8537 patch for kubespray 2.18.0.
- Add extract-kubespray.sh.

## v2.18.0-1 - 2022/02/12

- Add #8339, #8340 patches for kubespray 2.18.0.
- Rename prepare-docker.sh to install-docker.sh, remove it from download-all.sh. 

## v2.18.0-0 - 2022/02/06

- Support Kubespray 2.18.0
- Use containerd instead of Docker
- Add AlmaLinux 8 support, and remove CentOS 8
- Bug fixes

## v0.0.1 - 2021/08/26

- Initial release
- Support Kubespray 2.16.0
