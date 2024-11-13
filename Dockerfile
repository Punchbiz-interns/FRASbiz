# Use a lightweight Windows-based Python image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set the working directory in the container
WORKDIR /app

# Copy and install system dependencies (if any) from packages.txt
COPY packages.txt . 

RUN powershell -Command `
    if (Test-Path packages.txt) { `
        Get-Content packages.txt | ForEach-Object { `
            choco install $_ -y `
        } `
    }

# Install Python (if not included in the base image)
RUN powershell -Command `
    Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.9.9/python-3.9.9-amd64.exe -OutFile python.exe; `
    Start-Process python.exe -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -NoNewWindow -Wait; `
    Remove-Item python.exe

# Copy requirements.txt and pre-built .whl files (e.g., dlib) into the container
COPY requirements.txt requirements.txt
COPY *.whl /app/

# Install Python dependencies from requirements.txt and any .whl files
RUN python -m pip install --no-cache-dir -r requirements.txt
RUN python -m pip install --no-cache-dir *.whl

# Copy all application files from your repository into the container
COPY . .

# Expose the port that Streamlit uses (default: 8501)
EXPOSE 8501

# Run the Streamlit app
CMD ["streamlit", "run", "streamlit_app.py"]
