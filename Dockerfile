FROM openfaas/of-watchdog:0.5.3 as watchdog
FROM python:3.7

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

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

ENV fprocess="python index.py"

ENV cgi_headers="true"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:5000"

HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
