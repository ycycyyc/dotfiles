# stow （必须！！！）
1. git clone 到home目录下
2. 需要下载stow管理模块配置
```
macos: brew install stow
centos: sudo yum install stow
```

3. 拷贝module配置文件
```
module有 nvim tmux clangd 。。。
安装模块配置 stow {module_name}
删除模块配置 stow -D {module_name}
```

## nvim配置
1. neovim(needed)   version >= 0.5
```
install neovim from source

cd /usr/local/
mkdir nvim
// 在其他目录下载编译
git clone https://github.com/neovim/neovim -b release-0.8
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/usr/local/nvim
make install

export PATH="/usr/local/nvim/bin/":${PATH}
打开nvim, 输入 :version
确认是版本号以及编译类型 Build type: Release
```
1.1 安装packer插件管理器 https://github.com/wbthomason/packer.nvim
```
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```
1.2  打开nvim后运行  :PackerInstall
2. install ripgrep(needed)
3. install nodejs(recommand：方便安装各种lsp)
4. install bat(optional)
5. install lsp(go c++ rust...)(optional)


## tmux配置
1. tmux(needed)(尽量高版本)

## clangd配置
1. clangd (needed)

## centos配置 包括了 nvim rg bat
1. export PATH="$PATH:$HOME/dotfiles/centors/bin"

## neovim env
1. export VIM_COLO=""
2. export CLANGD_PATH=<youpath>
3. export SUMNEKO_ROOT_PATH=<youpath>
3. export SUMNEKO_BINARY=<youpath>

## clang/clangd/lldb build
1. git clone https://github.com/llvm/llvm-project
2. cd {llvm-project}
3. cmake  -S llvm -B build  -G "Unix Makefiles" -DLLVM_ENABLE_PROJECTS="clang;lldb;clang-tools-extra"   -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/llvm
4. cmake --build build -j16 
5. cd build
6. make install
