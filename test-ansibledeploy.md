    virtualenv ./venv
    source ./venv/bin/activate
    pip freeze > requirements.txt
    pip install -r requirements.txt
    pip install netaddr
