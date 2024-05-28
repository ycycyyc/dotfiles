## install
### vim-plug
https://github.com/junegunn/vim-plug#installation

### nodejs
官网下载二进制 or 'curl -sL install-node.vercel.app/lts | bash'

### vim(vim9 required)
git clone  https://github.com/vim/vim.git
./configure --prefix=/usr/local/vim
make 
make install
export PATH="/usr/local/vim/bin/":${PATH}

## config
cd ~
ln -s ~/dotfiles/vim/.vimrc .vimrc

run :PlugInstall to install plugin
