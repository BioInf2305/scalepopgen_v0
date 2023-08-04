import sys
import yaml
import numpy as np
from yaml.loader import SafeLoader
import folium
import folium.plugins
import folium.map
from geopy.geocoders import Nominatim

# from folium import plugins
from branca.element import Template, MacroElement
from folium.features import DivIcon


template = """
{% macro html(this, kwargs) %}
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>jQuery UI Draggable - Default functionality</title>
<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
<script>
$( function() {
$( "#maplegend" ).draggable({
            start: function (event, ui) {
                $(this).css({
                    right: "auto",
                    top: "auto",
                    bottom: "auto"
                });
            }
        });
});

</script>
</head>
<body>


<div id='maplegend' class='maplegend' 
style='position: absolute; z-index:9999; border:2px solid grey; background-color:rgba(255, 255, 255, 0.8);
border-radius:6px; padding: 10px; font-size:20px; right: 30px; bottom: 30px;'>

<div class='legend-title'>Breed sample_size</div>
<div class='legend-scale'>
<ul class='legend-labels'>
color_lines
</ul>
</div>
</div>

</body>
</html>

<style type='text/css'>
.maplegend .legend-title {
text-align: left;
margin-bottom: 5px;
font-weight: bold;
font-size: 90%;
}
.maplegend .legend-scale ul {
margin: 0;
margin-bottom: 5px;
padding: 0;
float: left;
list-style: none;
}
.maplegend .legend-scale ul li {
font-size: 80%;
list-style: none;
margin-left: 0;
line-height: 18px;
margin-bottom: 2px;
}
.maplegend ul.legend-labels li span {
display: block;
float: left;
height: 16px;
width: 30px;
margin-right: 5px;
margin-left: 0;
border: 1px solid #999;
}
.maplegend .legend-source {
font-size: 100%;
color: #777;
clear: both;
}
.maplegend a {
color: #777;
}
</style>
{% endmacro %}"""


def plot_sample_map(sample_map, param_yaml, tile_yaml):
    cc_tiles = ["Stamen Terrain","OpenStreetMap"]
    with open(param_yaml, "r") as p:
        params = yaml.load(p, Loader=SafeLoader)
    with open(tile_yaml, "r") as t:
        tiles = yaml.load(t, Loader=SafeLoader)
    output_file = params["output_prefix"] + ".html"
    tile = tiles[params["tile"]]["address"] if params["tile"] not in cc_tiles else params["tile"]
    attr_1 = tiles[params["tile"]]["attr"] if params["tile"] not in cc_tiles else "none"
    display_size = params["display_sample_size"]
    overlap_cordi = params["overlap_cordi"]
    display_popup = params["display_popup"]
    shift_cordi = params["shift_cordi"]
    show_legend = params["show_legend"]
    show_label = params["show_label"]
    label_loc = params["label_loc"]
    label_size = params["label_size"]
    sample_map_dict = {
        "pop": [],
        "lat": [],
        "lon": [],
        "sample_size": [],
        "pheno": [],
        "colr": [],
    }
    col_list = []
    header = 0
    with open(sample_map) as source:
        for line in source:
            line = line.rstrip().split("\t")
            geolocator = Nominatim(user_agent="my_request")
            if "," not in line[0]:
                location1 = geolocator.geocode(str(line[0]))
                lat_cord = location1.latitude
                lon_cord = location1.longitude
            else:
                lat_cord = float(line[0].split(",")[0])
                lon_cord = float(line[0].split(",")[1])
            sample_map_dict["pop"].append(line[1])
            sample_map_dict["lat"].append(lat_cord)
            sample_map_dict["lon"].append(lon_cord)
            sample_map_dict["sample_size"].append(int(line[3]))
            sample_map_dict["pheno"].append(line[2])
            sample_map_dict["colr"].append(line[4])
            col_list.append([line[2] + " " + line[3], line[4]])
    if tile in cc_tiles:
        mapit = folium.Map(
            tiles=tile,
            location=[10, 30],
            zoom_start=3,
        )
    else:
        mapit = folium.Map(
            tiles=tile,
            attr=attr_1,
            location=[10, 30],
            zoom_start=3,
        )
    for i in range(len(sample_map_dict["pop"])):
        popup_label = (
            (sample_map_dict["pop"][i] + " " + str(sample_map_dict["sample_size"][i]))
            if display_size
            else sample_map_dict["pop"][i]
        )
        if overlap_cordi:
            new_lat = (
                sample_map_dict["lat"][i]
                + np.random.uniform(0.001, 10 ** (-20))
                - shift_cordi
            )
            new_lon = (
                sample_map_dict["lon"][i]
                + np.random.uniform(0.001, 10 ** (-20))
                - shift_cordi
            )
        else:
            new_lat, new_lon = sample_map_dict["lat"][i], sample_map_dict["lon"][i]
        radius_size = (
            (float(params["marker_prop"]) * sample_map_dict["sample_size"][i])
            if params["marker_prop"] != 0
            else params["const_radius"]
        )
        folium.CircleMarker(
            location=[new_lat, new_lon],
            popup=folium.Popup(popup_label, show=True if display_popup else False),
            radius=radius_size,
            color=sample_map_dict["colr"][i],
            fill=True,
            fill_color=sample_map_dict["colr"][i],
            fill_opacity=0.7,
        ).add_to(mapit)
        if show_label:
            folium.map.Marker(
                [new_lat + label_loc, new_lon - label_loc],
                icon=DivIcon(
                    icon_size=(15, 3.6),
                    icon_anchor=(0, 0),
                    html='<div style="font-size: %s">%s</div>' % (label_size, popup_label),
                    #html='<div style="font-size: '+label_size+'>%s</div>' % popup_label,
                ),
            ).add_to(mapit)
    if show_legend:
        legend_line = "<li><span style='background:{};opacity:0.7;'></span>{}</li>"
        legend_line_collect = ""
        for pop, color in col_list:
            new_legend = legend_line.format(color, pop)
            legend_line_collect = legend_line_collect + " " + new_legend
        new_template = template.replace("color_lines", legend_line_collect)
        macro = MacroElement()
        macro._template = Template(new_template)
        mapit.get_root().add_child(macro)
        mapit.get_root().html.add_child(macro)
    mapit.save(output_file)


if __name__ == "__main__":
    plot_sample_map(sys.argv[1], sys.argv[2], sys.argv[3])
