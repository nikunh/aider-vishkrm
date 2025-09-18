import json
import subprocess
import requests
import os
import sys
import venv
from pathlib import Path

# Constants
OPENROUTER_API = "https://openrouter.ai/api/v1"
CONFIG_FILE = 'aider_config.json'
STATE_FILE = 'project_state.json'
VENV_DIR = '.venv'
REQUIREMENTS_FILE = 'requirements.txt'

# def check_dependencies():
#     required_packages = ['requests', 'aider']
#     with open(REQUIREMENTS_FILE, 'w') as f:
#         for package in required_packages:
#             f.write(f"{package}\n")
    
#     if not os.path.exists(VENV_DIR):
#         print("Creating virtual environment...")
#         venv.create(VENV_DIR, with_pip=True)
    
#     venv_python = os.path.join(VENV_DIR, 'bin', 'python')
#     subprocess.run([venv_python, '-m', 'pip', 'install', '-r', REQUIREMENTS_FILE])
    
#     if sys.prefix != sys.base_prefix:
#         print("Already in a virtual environment.")
#     else:
#         print("Switching to virtual environment...")
#         os.execv(venv_python, [venv_python] + sys.argv)

def get_openrouter_creds():
    creds = os.environ.get('OPENROUTER_API_KEY')
    if not creds:
        print("OpenRouter API key not found in environment variables.")
        print("You can get your API key from https://openrouter.ai/keys")
        creds = input("Please enter your OpenRouter API key: ")
        os.environ['OPENROUTER_API_KEY'] = creds
    return creds

def load_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    else:
        print(f"Configuration file {CONFIG_FILE} not found.")
        sys.exit(1)

def get_model_parameters(model_name, api_key):
    headers = {"Authorization": f"Bearer {api_key}"}
    response = requests.get(f"{OPENROUTER_API}/models/{model_name}", headers=headers)
    return response.json()

def select_model(task, config):
    for model in config['models']:
        if task.lower() in model['use_case'].lower():
            return model
    return None

def run_aider_command(model, task, input_text, api_key):
    command = f"aider --model openrouter/{model['provider']}/{model['model']} --api-key {api_key} --task {task} '{input_text}'"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result.stdout

def refine_features(features, config, api_key):
    model = select_model("brainstorming", config)
    while True:
        print("Current features:", features)
        user_input = input("Refine features or type 'final' to proceed: ")
        if user_input.lower() == 'final':
            break
        features = run_aider_command(model, "refine_features", f"Refine these features: {features}\nUser input: {user_input}", api_key)
    return features

def create_project_artifacts(features, config, api_key):
    artifacts = ["hld", "lld", "readme", "project_goals"]
    for artifact in artifacts:
        model = select_model(artifact, config)
        content = run_aider_command(model, f"create_{artifact}", f"Create {artifact} for features: {features}", api_key)
        with open(f"{artifact}.md", "w") as f:
            f.write(content)

def implement_features(features, codebase_path, config, api_key):
    model = select_model("implementation", config)
    while True:
        result = run_aider_command(model, "implement_features", f"Implement these features in the codebase at {codebase_path}: {features}", api_key)
        print(result)
        user_input = input("Are the features implemented correctly? (yes/no): ")
        if user_input.lower() == 'yes':
            break
        else:
            feedback = input("Provide feedback for improvements: ")
            features += f"\nFeedback: {feedback}"

def save_project_state(features, discussion, codebase_path):
    with open(STATE_FILE, "w") as f:
        json.dump({"features": features, "discussion": discussion, "codebase_path": codebase_path}, f)

def load_project_state():
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, "r") as f:
            return json.load(f)
    return None

def main():
    # check_dependencies()
    api_key = get_openrouter_creds()
    config = load_config()

    state = load_project_state()
    if state:
        print("Previous session found. Do you want to continue? (yes/no)")
        if input().lower() == 'yes':
            features = state['features']
            discussion = state['discussion']
            codebase_path = state['codebase_path']
        else:
            state = None

    if not state:
        codebase_path = input("Enter the path to your codebase: ")
        features = input("Describe the features you want to implement: ")
        discussion = []

    # Query model parameters from OpenRouter
    for model in config['models']:
        params = get_model_parameters(f"{model['provider']}/{model['model']}", api_key)
        model['parameters'] = params
        print(f"Model: {model['title']}")
        print(f"Parameters: {params}")
        print("---")

    # Refine features
    features = refine_features(features, config, api_key)
    discussion.append(f"Refined features: {features}")

    # Create project artifacts
    create_project_artifacts(features, config, api_key)
    discussion.append("Created project artifacts")

    # Implement features
    implement_features(features, codebase_path, config, api_key)
    discussion.append("Implemented features")

    # Save project state
    save_project_state(features, discussion, codebase_path)
    print(f"Project state saved in {STATE_FILE}. You can resume this session later.")

if __name__ == "__main__":
    main()
