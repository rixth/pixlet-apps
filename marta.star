load("schema.star", "schema")
load("render.star", "render")
load("time.star", "time")

load("http.star", "http")

def get_data(api_key):
    res = http.get("https://developerservices.itsmarta.com:18096/itsmarta/railrealtimearrivals/developerservices/traindata?apiKey=" + api_key, ttl_seconds=30)
    if res.status_code != 200:
        fail("GET failed with status %d: %s", res.status_code, res.body())
    return res.json()

def main(config):
    api_key = config.get("api_key")

    if not api_key:
        fail("api_key is required")

    data = get_data(api_key)
    decatur_station = [stn for stn in data if stn["STATION"] == "DECATUR STATION"]
    eastbound_trains = [train for train in decatur_station if train["DIRECTION"] == "E"][:3]

    return render.Root(
        delay = 750,
        child = render.Column(
                # render a child for each train
                children = [
                    render.Row(
                        children = [
                            render.Box(
                                height = 8,
                                width = 4,
                                color="#FF7500"
                            ),
                            render.Box(
                                height = 8,
                                width = 4,
                                color="#FDBE43"
                            ),
                            render.Box(
                                height = 8,
                                width = 4,
                                color="#0092D0"
                            ),
                            render.Box(
                                height = 8,
                                width = 2,
                                color="#000"
                            ),
                            render.Text(
                                content = "Next MARTA",
                                font = "5x8",
                            )
                        ],
                    )
                ] +
                    [render.Padding(
                        pad=(3,0,0,0),
                        child = render.Text(
                            content = train["WAITING_TIME"],
                            font = "5x8",
                        )
                    )
                    for train in eastbound_trains
                ]
            ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "api_key",
                name = "API Key",
                desc = "Your MARTA API key.",
                icon = "key",
            ),
        ],
    )