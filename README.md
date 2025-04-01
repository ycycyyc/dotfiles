# stow （必须！！！）
1. git clone 到home目录下
2. 需要下载stow管理模块配置
```
macos: brew install stow
centos: sudo yum install stow
```

3. install module config file
```
module有 nvim tmux clangd vim
install module:   stow {module_name}
uninstall module: stow -D {module_name}
```

4. 环境配置
在 .zshrc 中添加下一行
```
source ~/dotfiles/persional/.persionalrc
```

## nvim配置
1. neovim(needed)   
```
版本较低的linux系统可以从: https://github.com/neovim/neovim-releases/releases 拷贝二进制
或者从源码开始编译
mkdir nvim
git clone https://github.com/neovim/neovim -b {最新的release分支}
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/usr/local/nvim
make install

export PATH="/usr/local/nvim/bin/":${PATH}
:verion
build type: Release
```
1. install plug manager: lazy.nvim
2. install ripgrep(needed)
3. install nodejs(recommand)
4. install bat(optional)
5. install lsp(gopls clangd ..)(optional)


## tmux配置
1. tmux(needed)(尽量高版本)

## clangd配置
1. clangd (needed)

## install gopls
1. go install golang.org/x/tools/gopls@v0.14.3

## neovim env
1. export NVIM_JSON_CONF='{}'

## clang/clangd/lldb build
1. git clone https://github.com/llvm/llvm-project
2. cd {llvm-project}
3. cmake  -S llvm -B build  -G "Unix Makefiles" -DLLVM_ENABLE_PROJECTS="clang;lldb;clang-tools-extra"   -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/llvm
4. cmake --build build -j16 
5. cd build
6. make install
