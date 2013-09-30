nmap <leader>g :w\|:silent !echo "bundle exec ruby spec/scrappy_import_run.rb" > test-commands<cr>
nmap <leader>G :w\|:silent !echo "bundle exec rspec spec" > test-commands<cr>
