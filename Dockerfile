# Use a lightweight Windows-based Python image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set the working directory in the container
WORKDIR /app

# Install Chocolatey
RUN powershell -Command \
    "Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; \
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

# Copy packages.txt into the container (optional)
COPY packages.txt .

# Install dependencies from packages.txt using Chocolatey if packages.txt exists
RUN powershell -Command \
    "if (Test-Path 'packages.txt') { \
        Get-Content packages.txt | ForEach-Object { choco install $_ -y }; \
    }"

# Copy requirements.txt and pre-built .whl files (e.g., dlib) into the container
COPY requirements.txt requirements.txt
COPY *.whl /app/

# Install Python dependencies from requirements.txt and any .whl files
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir /app/*.whl

# Copy all application files from your repository into the container
COPY . .

# Expose the port that Streamlit uses (default: 8501)
EXPOSE 8501

# Run the Streamlit app
CMD ["streamlit", "run", "streamlit_app.py"]
