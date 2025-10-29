from flask import Flask, request, redirect, render_template
import sqlite3
from datetime import datetime

DB_PATH = "notes.db"
app = Flask(__name__)

# Initialize database
def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS notes
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  content TEXT,
                  tag TEXT,
                  created_at TEXT)''')
    conn.commit()
    conn.close()

@app.route("/", methods=["GET", "POST"])
def index():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()

    # Add new note
    if request.method == "POST":
        note = request.form.get("note")
        tag = request.form.get("tag") or "General"
        if note:
            c.execute("INSERT INTO notes(content, tag, created_at) VALUES (?, ?, ?)",
                      (note, tag, datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
            conn.commit()

    # Search functionality
    search = request.args.get("search")
    if search:
        c.execute("SELECT id, content, tag, created_at FROM notes WHERE content LIKE ? OR tag LIKE ? ORDER BY id DESC",
                  (f"%{search}%", f"%{search}%"))
    else:
        c.execute("SELECT id, content, tag, created_at FROM notes ORDER BY id DESC")

    notes = c.fetchall()
    conn.close()
    return render_template("index.html", notes=notes, search=search or "")

@app.route("/delete/<int:id>", methods=["POST"])
def delete(id):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("DELETE FROM notes WHERE id = ?", (id,))
    conn.commit()
    conn.close()
    return redirect("/")

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=80)
