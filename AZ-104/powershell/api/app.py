"""API TrackIt : suivi de palettes (version de demonstration pour le bootcamp AZ-104)."""
import os
import socket

from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/api/palettes/<pid>")
def palette(pid):
    return jsonify(
        palette=pid,
        statut="En transit - Lyon vers Nantes",
        temperature_c=-18.2,
        instance=socket.gethostname(),
        version=os.getenv("API_VERSION", "1.0"),
    )


@app.get("/health")
def health():
    return "OK", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
