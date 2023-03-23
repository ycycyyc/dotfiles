## install
### vim-plug
https://github.com/junegunn/vim-plug#installation

### nodejs
官网下载二进制 or 'curl -sL install-node.vercel.app/lts | bash'

### vim
git clone  https://github.com/vim/vim.git
./configure --prefix=/usr/local/vim
make 
make install
export PATH="/usr/local/vim/bin/":${PATH}

## config
cd ~
mv .vimrc .vimrc.bak 
ln -s ~/dotfile/vim/.vimrc .vimrc
cd .vim
ln -s  ~/dotfile/vim/coc-settings.json coc-settings.json
mkdir -p ~/.vim/after/syntax/
ln -s ~/dotfile/vim/go.vim ~/.vim/after/syntax/go.vim

run :PlugInstall to install plugin
