Pytest timeouts with psutils
=============================

This small project is a small playground poc for handling timeouts in pytest and uses [psutils](https://psutil.readthedocs.io/en/latest/) to create subprocess and send signals to them in case a timeout happens

Usage
=====

```shell
python -m venv venv
./venv/Scripts/activate
pip install -r requirements.txt

python psutils.py
```