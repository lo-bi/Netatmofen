# Netatmofen

Ingest data from Ökofen pellet boilers and Netatmo weather station into TIG (Telegraf, InfluxDB, Grafana)

## Installation

### Enable JSON-Interface on your Ökofen Boiler
Go to your Ökofen Boiler-> Touchscreen -> Open General Settings -> Network Settings -> Scroll down -> Activate JSON Interface (do not select compatibility mode) 
Note the password to access the JSON interface (used in OKOFEN_URL)

### Global Environment 
Create a `.env` file and fill the following variable

```
DOCKER_INFLUXDB_INIT_USERNAME=telegraf_user
DOCKER_INFLUXDB_INIT_PASSWORD=telegraf_password
DOCKER_INFLUXDB_INIT_ORG=telegraf
DOCKER_INFLUXDB_INIT_BUCKET=telegraf
DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=telegraf_password

GF_SECURITY_ADMIN_USER=grafana_user
GF_SECURITY_ADMIN_PASSWORD=grafana_password

OKOFEN_URL=http://okofen:4321/<PASSWORD>/all
```

### Netatmo setup

**It is not mandatory to use Netatmo, if you only want to ingest data from your Okofen boiler, delete the script files in `telegraf/scripts/netatmo.conf` and `telegraf/scripts/netatmo_public_data.conf`**

Otherwise, copy file `netatmo/netatmo.yml.exemple` to `netatmo/netatmo.yml` and fill up the variables.
You can generate a client_id, client_secret and a refresh_token through https://dev.netatmo.com
Your device_id is your weather station ID. 
Coordinates variables are used if you want to also fetch weather data from a close station (which for instance has the rain or wind module). Simply find the coordinate here: https://weathermap.netatmo.com - **If you don't want to use this function, delete `telegraf/scripts/netatmo_public_data.conf`**

```
client_id: 1234
client_secret: abcd
refresh_token: 1234|6789
device_id: 70:xx:xx:xx:xx:xx
include_station_name: false
lat_ne: 47.294
lon_ne: 3.2720
lat_sw: 36.2923
lon_sw: 2.2691
```

## Usage

```bash
docker-compose up -d
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

## License

[MIT](https://choosealicense.com/licenses/mit/)
