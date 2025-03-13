# Useful trick for handling GIT and filtering security breaches
# For example keys leaking on repository

git filter-branch --index-filter 'git rm -rf --cached --ignore-unmatch path_to_file' HEAD

