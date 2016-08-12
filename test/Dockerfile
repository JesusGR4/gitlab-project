FROM desatranques/base

COPY test-requirements.txt .
RUN pip install -r test-requirements.txt 

WORKDIR /var/nameko/
COPY . /var/nameko/

RUN pip install -r orders/requirements.txt 
RUN pip install -r products/requirements.txt
RUN pip install -r gateway/requirements.txt

COPY test/ .