from flask import Flask, request, redirect, render_template
import pymysql
from datetime import datetime

# RDS MySQL Configuration
import os

DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "database": os.getenv("DB_NAME", "notesdb")
}


app = Flask(__name__)

# Initialize database
def init_db():
    conn = pymysql.connect(**DB_CONFIG)
    with conn.cursor() as c:
        c.execute("""
            CREATE TABLE IF NOT EXISTS notes (
                id INT AUTO_INCREMENT PRIMARY KEY,
                content TEXT,
                tag VARCHAR(100),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
    conn.commit()
    conn.close()

def get_db_connection():
    return pymysql.connect(**DB_CONFIG)

@app.route("/", methods=["GET", "POST"])
def index():
    conn = get_db_connection()
    c = conn.cursor()

    # Add new note
    if request.method == "POST":
        note = request.form.get("note")
        tag = request.form.get("tag") or "General"
        if note:
            c.execute("INSERT INTO notes(content, tag, created_at) VALUES (%s, %s, %s)",
                      (note, tag, datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
            conn.commit()

    # Search functionality
    search = request.args.get("search")
    if search:
        c.execute("SELECT id, content, tag, created_at FROM notes WHERE content LIKE %s OR tag LIKE %s ORDER BY id DESC",
                  (f"%{search}%", f"%{search}%"))
    else:
        c.execute("SELECT id, content, tag, created_at FROM notes ORDER BY id DESC")

    notes = c.fetchall()
    conn.close()
    return render_template("index.html", notes=notes, search=search or "")

@app.route("/delete/<int:id>", methods=["POST"])
def delete(id):
    conn = get_db_connection()
    c = conn.cursor()
    c.execute("DELETE FROM notes WHERE id = %s", (id,))
    conn.commit()
    conn.close()
    return redirect("/")

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=80)
