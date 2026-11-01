FROM python:3.11-slim

WORKDIR /app

ENV NODE_ENV=production
# All browser traffic reaches Flask through nginx, so this bucket is shared.
ENV RATE_LIMIT="1000 per 15 minutes"

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

RUN python seed_database.py

EXPOSE 3000

CMD ["python", "-m", "src.main"]
