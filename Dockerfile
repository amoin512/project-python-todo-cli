FROM python:3.9-slim
WORKDIR /cli-app
COPY code.py /cli-app
CMD [ "python", "code.py" ]