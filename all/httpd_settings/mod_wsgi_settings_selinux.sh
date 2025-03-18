sudo semanage fcontext -a -t httpd_exec_t '/home/vinnix/.pyenv/versions/3.12.9/lib/.*\.so(\..*)?'

restorecon -r /home/vinnix/.pyenv/versions/3.12.9/lib/

sudo semanage fcontext -a -t httpd_exec_t '/home/vinnix/.pyenv/versions/3.12.9/lib/python3.12/site-packages/mod_wsgi/server/.*\.so(\..*)?'

restorecon -r /home/vinnix/.pyenv/versions/3.12.9/lib/python3.12/site-packages/mod_wsgi/server/

