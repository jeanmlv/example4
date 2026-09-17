# example4

git config --global user.name "Mendes, Jean [JRDUS Non-J&J]"

git config --global user.email "JMende95@its.jnj.com"

git commit --amend --reset-author --no-edit

git remote add origin https://sourcecode.jnj.com/scm/~jmende95/arges_commons_dash.git

git remote -v

git push -u origin main
