# GTA Mobile Cheat Code Manager

This bash script allows you to store and easily enter Grand Theft Auto (GTA) cheat codes on your mobile device.

## Usage

Open the script in a text editor and set the `data_file` variable to the desired name of the file where you want to store the cheat codes.

Set the `delim` variable to the delimiter you want to use to separate the description and code in the data file.

Set the `wait_time` variable to the number of seconds you want to wait between entering cheat codes.



### Setup

    chmod +x gcm.sh

### Setup Termux (Optional)
- Enable `Wireless Debugging` under `Developer Options`.
- Run `pkg install android-tools` to install adb on termux.
- If your device required pairing you can run `adb pair [HOST]:[PORT]`.
- Once paired you can run `adb connect [HOST]:[PORT]` to connect to your device.

### Run

    ./gcm.sh

The script will prompt you to enter numbers or a range of numbers to select cheat codes. You can also enter n to create a new entry or t to display the cheat codes in a table.

Once you have selected the cheat codes you want to enter, the script will prompt you to enter an interval in seconds. The script will then enter the selected cheat codes at the specified interval.


### Notes

- Make sure you have the adb tool installed and set up on your device before running the script.

- The script uses the adb shell input text command to enter the cheat codes, so make sure you are in the correct input field in the game before running the script.

- The script will continue to run until it is terminated using CTRL+C.

- There's a csv file `sa_cheats.csv` with all the cheat code for GTA San Andreas mobile I could find.