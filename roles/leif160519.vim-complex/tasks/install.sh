---
- shell: /usr/bin/gcc --version | head -1 | awk '{print $NF}'
  register: gcc_installed_version

- shell: /usr/bin/vim --version | grep IMproved | awk '{print $5}'
  register: vim_installed_version

- name: install vim and related dependencies  # 确保vim版本在8.1.2269及以上
  package:
    name: "{{ item }}"
    state: latest
  with_items:
    - vim
    - golang-go
    - make
    - cmake
    - clang
    - python3
    - g++-8
