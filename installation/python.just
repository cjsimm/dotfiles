PYTHON_PACKAGE_FILE := source_dir() + "packages/python.txt"

# Install common python packages for the global python installation
install-pypi:
    #!/usr/bin/env sh
    echo 'Installing python packages listed in python.txt...'
    while read -r package; do
        pip install "$package"
    done < {{PYTHON_PACKAGE_FILE}}

# installs the beancount double entry finance software via a git clone and pip install in the base python installation
install-beancount:
    #!/usr/bin/env sh
    git clone https://github.com/beancount/beancount
    pip install beancount/
    rm -rf beancount


