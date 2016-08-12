FROM desatranques/base

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . /var/nameko/

WORKDIR /var/nameko/

CMD /var/nameko/run.sh
