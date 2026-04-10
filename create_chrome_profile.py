# For creating tg-web-profile-firefox
# & "C:\Program Files\Mozilla Firefox\firefox.exe" -CreateProfile "tgweb C:\tg-web-profile-firefox"

from selenium import webdriver
from selenium.webdriver.chrome.options import Options

options = Options()
options.add_argument(r"--user-data-dir=C:\tg-web-profile")
options.add_argument(r"--profile-directory=Default")

driver = webdriver.Remote(
    command_executor="http://127.0.0.1:9515",
    options=options
)

driver.get("https://web.telegram.org/a/")
input("Log in manually in the VM, then press Enter...")
driver.quit()