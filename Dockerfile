# Use a lightweight Python base image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the packages.txt file if it exists (for system-level dependencies)
COPY packages.txt .

# Install system dependencies if packages.txt exists
RUN if [ -f packages.txt ]; then \
      apt-get update && \
      xargs -a packages.txt apt-get install -y && \
      rm -rf /var/lib/apt/lists/*; \
    fi

# Copy requirements.txt into the container
COPY requirements.txt requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy all files from your repository into the container
COPY . .

# Expose the port that Streamlit uses (default: 8501)
EXPOSE 8501

# Run the Streamlit app
CMD ["streamlit", "run", "streamlit_app.py"]
