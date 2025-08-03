# installs the beancount double entry finance software via a git clone and pip install in the base python installation
install-beancount:
    #!/usr/bin/env sh
    git clone https://github.com/beancount/beancount
    pip install beancount/
    rm -rf beancount


