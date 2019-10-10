FROM python:3.7

ARG ADDITIONAL_PACKAGE
RUN apt-get update && apt-get install -y musl-dev gcc make ${ADDITIONAL_PACKAGE}
RUN apt-get install -y python-scipy

RUN addgroup app && adduser app --ingroup app
RUN chown app /home/app

USER app

ENV PATH=$PATH:/home/app/.local/bin

WORKDIR /home/app

COPY index.py           .
COPY requirements.txt   .
USER root
RUN python3 -m pip install -r requirements.txt
USER app

RUN mkdir -p function
RUN touch ./function/__init__.py
WORKDIR /home/app/function/
COPY function/requirements.txt	.

RUN python3 -m pip install --user -r requirements.txt

WORKDIR /home/app

USER root
COPY function   function
RUN chown -R app:app ./
USER app

ENTRYPOINT ["python3"]
CMD ["index.py"]
