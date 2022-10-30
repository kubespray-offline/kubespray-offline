# ChangeLogs

## v2.19.1-2 - 2022/10/30

- Fix local nginx port number (#12)

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
