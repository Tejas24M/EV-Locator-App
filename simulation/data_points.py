import math
from geopy.distance import geodesic, great_circle
from geopy import Point
import requests
import json

def get_data():
    path_1 = [
        (19.13545428237426, 72.90614017839307),
        (19.13494494619806, 72.9083006977471),
        (19.13435198568622, 72.91009643671495),
        (19.133382345064238, 72.91265116307086),
        (19.132589189046687, 72.91467757197887),
        (19.131668058985294, 72.91528106901404),
        (19.131356368689072, 72.91534812427243),
        (19.130280652568494, 72.91544468379965),
        (19.129600248998504, 72.91543395494249),
        (19.128452299194006, 72.91539506292271),
        (19.126888513750142, 72.91570362682783),
        (19.12594826308112, 72.91617251302843),
        (19.125803608661478, 72.9162905319911)
    ]

    path_2 = [
        (19.13777590157055, 72.91493353245139),
        (19.137656804879665, 72.91514542694026),
        (19.13714747550889, 72.91496571895603),
        (19.136022384151797, 72.91470822689682),
        (19.135345805241787, 72.91449096796453),
        (19.13430432443574, 72.91417714952486),
        (19.133006898774063, 72.91380432247654),
        (19.13251782745557, 72.91475918883101),
        (19.13166384973539, 72.91529831282054),
        (19.13072117483931, 72.9153975545553),
        (19.13010285827127, 72.9154646097771),
        (19.12958083509276, 72.91543778769552),
        (19.128303645264292, 72.91540023677906),
        (19.126851590068256, 72.91570600858559),
        (19.125803608661478, 72.9162905319911)
    ]

    path_1_str = " | ".join([f"{lat}, {lon}" for lat, lon in path_1])
    path_2_str = " | ".join([f"{lat}, {lon}" for lat, lon in path_2])

    # Define the API endpoint and parameters
    url = 'https://roads.googleapis.com/v1/snapToRoads'
    params = {
        'path': path_2_str,
        'interpolate': 'true',
        'key': 'AIzaSyDz8CKcfCnCtvkbjwK-tTcZtc96ku8JUJ0'
    }

    # Send the request
    response = requests.post(url, params=params)

    # Check the response
    if response.status_code == 200:
        data = response.json()
        # print(data)
        for snapped_point in data['snappedPoints']:
            print(f"{snapped_point['location']}")
    else:
        print(f"Error: {response.status_code}")

coordinates_1 = [
    (19.1354452371466, 72.90613732217639),
    (19.1353902, 72.90633260000001),
    (19.1353902, 72.90633260000001),
    (19.135304399999995, 72.90674530000001),
    (19.135304399999995, 72.90674530000001),
    (19.1352475, 72.907091),
    (19.1352475, 72.907091),
    (19.1351591, 72.90754079999999),
    (19.1350741, 72.9078851),
    (19.1350741, 72.9078851),
    (19.1349812, 72.908182),
    (19.1349812, 72.908182),
    (19.134946199999998, 72.90830009999999),
    (19.134946199999998, 72.90830009999999),
    (19.134896400000002, 72.90843509999999),
    (19.134896400000002, 72.90843509999999),
    (19.134778200000003, 72.9088103),
    (19.134778200000003, 72.9088103),
    (19.1347131, 72.9089781),
    (19.1347131, 72.9089781),
    (19.1345879, 72.90933509999999),
    (19.134336299999998, 72.9100881),
    (19.134336299999998, 72.9100881),
    (19.134336299999998, 72.9100881),
    (19.1342572, 72.9103161),
    (19.1342572, 72.9103161),
    (19.134117399999994, 72.9107188),
    (19.134117399999994, 72.9107188),
    (19.1339232, 72.9112293),
    (19.1339232, 72.9112293),
    (19.1336625, 72.9118469),
    (19.1336625, 72.9118469),
    (19.1335781, 72.9120882),
    (19.1335781, 72.9120882),
    (19.1335515, 72.91216419999999),
    (19.1335515, 72.91216419999999),
    (19.133383799999997, 72.91264439999999),
    (19.133383799999997, 72.91264439999999),
    (19.133101699999997, 72.9134973),
    (19.133101699999997, 72.9134973),
    (19.132989599999995, 72.9138265),
    (19.132989599999995, 72.9138265),
    (19.132923899999998, 72.9140183),
    (19.1328139, 72.91432189999999),
    (19.1328139, 72.91432189999999),
    (19.132744199999998, 72.914452),
    (19.132664500000004, 72.9145758),
    (19.1325923, 72.9146736),
    (19.1325923, 72.9146736),
    (19.1325126, 72.9147579),
    (19.1325126, 72.9147579),
    (19.1324482, 72.91481859999999),
    (19.1324482, 72.91481859999999),
    (19.132199699999994, 72.9149995),
    (19.132064400000004, 72.9150949),
    (19.131972999999995, 72.91514819999999),
    (19.131972999999995, 72.91514819999999),
    (19.1319119, 72.9151835),
    (19.1318557, 72.91521259999999),
    (19.1318557, 72.91521259999999),
    (19.131766199999998, 72.9152517),
    (19.131766199999998, 72.9152517),
    (19.131667900000004, 72.91527889999999),
    (19.131667900000004, 72.91527889999999),
    (19.13166720671391, 72.91527926744166),
    (19.1316479, 72.9152895),
    (19.1315644, 72.9153204),
    (19.1314736, 72.91534469999999),
    (19.1313589, 72.9153596),
    (19.1313589, 72.9153596),
    (19.1313589, 72.9153596),
    (19.130481, 72.9154298),
    (19.130481, 72.9154298),
    (19.1302892, 72.9154446),
    (19.1302892, 72.9154446),
    (19.130229, 72.91544999999999),
    (19.130112600000004, 72.9154539),
    (19.130112600000004, 72.9154539),
    (19.129600237475294, 72.91543429227939),
    (19.129592600000002, 72.91543399999999),
    (19.129592600000002, 72.91543399999999),
    (19.129167199999994, 72.9154339),
    (19.128452035255414, 72.91540161242794),
    (19.1284429, 72.91540119999999),
    (19.1284429, 72.91540119999999),
    (19.128290399999997, 72.9153959),
    (19.128290399999997, 72.9153959),
    (19.1279733, 72.9154009),
    (19.127854899999996, 72.9154165),
    (19.127728500000003, 72.9154301),
    (19.127473799999997, 72.9154783),
    (19.127114600000002, 72.915596),
    (19.12688480019404, 72.91569385734708),
    (19.1268638, 72.91570279999999),
    (19.1268638, 72.91570279999999),
    (19.1265567, 72.9158626),
    (19.126491699999995, 72.9159009),
    (19.126491699999995, 72.9159009),
    (19.126220500000002, 72.9160401),
    (19.126220500000002, 72.9160401),
    (19.126023399999994, 72.91612479999999),
    (19.1260004, 72.9161325),
    (19.1260004, 72.9161325),
    (19.125964106342252, 72.9161848240442),
    (19.1259078, 72.916266),
    (19.125838870832933, 72.91633186965221),
]

coordinates_2 = [
    (19.137775760596426, 72.91493296052465),
    (19.1377691, 72.9149348),
    (19.1377691, 72.9149348),
    (19.1377328, 72.9150028),
    (19.137647299999998, 72.9151335),
    (19.137647299999998, 72.9151335),
    (19.1371561, 72.9149686),
    (19.1371561, 72.9149686),
    (19.13714727812763, 72.91496751183779),
    (19.1368837, 72.914935),
    (19.136671799999995, 72.9148823),
    (19.13602306559573, 72.91470542656921),
    (19.136018200000002, 72.9147041),
    (19.136018200000002, 72.9147041),
    (19.1353858, 72.91449790000001),
    (19.1353858, 72.91449790000001),
    (19.135347136612502, 72.91448608618708),
    (19.135346199999997, 72.9144858),
    (19.135346199999997, 72.9144858),
    (19.134307092402103, 72.914167040154),
    (19.1342949, 72.9141633),
    (19.1342949, 72.9141633),
    (19.133958, 72.9140522),
    (19.133958, 72.9140522),
    (19.1338519, 72.9140206),
    (19.1338519, 72.9140206),
    (19.13300188733441, 72.91382926581126),
    (19.132989599999995, 72.9138265),
    (19.132989599999995, 72.9138265),
    (19.132923899999998, 72.9140183),
    (19.1328139, 72.91432189999999),
    (19.1328139, 72.91432189999999),
    (19.132744199999998, 72.914452),
    (19.132664500000004, 72.9145758),
    (19.1325923, 72.9146736),
    (19.1325923, 72.9146736),
    (19.132514606762495, 72.9147557774158),
    (19.1325126, 72.9147579),
    (19.1325126, 72.9147579),
    (19.1324482, 72.91481859999999),
    (19.1324482, 72.91481859999999),
    (19.132199699999994, 72.9149995),
    (19.132064400000004, 72.9150949),
    (19.131972999999995, 72.91514819999999),
    (19.131972999999995, 72.91514819999999),
    (19.1319119, 72.9151835),
    (19.1318557, 72.91521259999999),
    (19.1318557, 72.91521259999999),
    (19.131766199999998, 72.9152517),
    (19.131766199999998, 72.9152517),
    (19.131667900000004, 72.91527889999999),
    (19.131667900000004, 72.91527889999999),
    (19.1316479, 72.9152895),
    (19.1315644, 72.9153204),
    (19.1314736, 72.91534469999999),
    (19.1313589, 72.9153596),
    (19.1313589, 72.9153596),
    (19.130722100308503, 72.91541052083812),
    (19.130481, 72.9154298),
    (19.130481, 72.9154298),
    (19.1302892, 72.9154446),
    (19.1302892, 72.9154446),
    (19.130229, 72.91544999999999),
    (19.130112600000004, 72.9154539),
    (19.130112600000004, 72.9154539),
    (19.130103236351275, 72.91545354165926),
    (19.129592600000002, 72.91543399999999),
    (19.129592600000002, 72.91543399999999),
    (19.12958083588814, 72.91543399723456),
    (19.129167199999994, 72.9154339),
    (19.1284429, 72.91540119999999),
    (19.1284429, 72.91540119999999),
    (19.12830376539119, 72.91539636450173),
    (19.128290399999997, 72.9153959),
    (19.128290399999997, 72.9153959),
    (19.1279733, 72.9154009),
    (19.127854899999996, 72.9154165),
    (19.127728500000003, 72.9154301),
    (19.127473799999997, 72.9154783),
    (19.127114600000002, 72.915596),
    (19.1268638, 72.91570279999999),
    (19.1268638, 72.91570279999999),
    (19.1265567, 72.9158626),
    (19.126491699999995, 72.9159009),
    (19.126491699999995, 72.9159009),
    (19.126220500000002, 72.9160401),
    (19.126220500000002, 72.9160401),
    (19.126023399999994, 72.91612479999999),
    (19.1260004, 72.9161325),
    (19.1260004, 72.9161325),
    (19.1259078, 72.916266),
    (19.125838870832933, 72.91633186965221)
]

# Function to calculate the Haversine distance between two coordinates in meters
def haversine(lat1, lon1, lat2, lon2):
    # Radius of the Earth in meters
    R = 6371000.0
    
    # Convert latitude and longitude from degrees to radians
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)

    # Difference in coordinates
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad

    # Haversine formula
    a = math.sin(dlat / 2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    # Distance in meters
    distance = R * c
    return distance

# Function to find the nearest coordinate
def find_nearest_coordinate(input_lat, input_lon, coordinates):
    min_distance = float('inf')
    nearest_coordinate = None

    for coord in coordinates:
        lat, lon = coord
        distance = haversine(input_lat, input_lon, lat, lon)
        if distance < min_distance:
            min_distance = distance
            nearest_coordinate = coord

    return nearest_coordinate, min_distance

# Function to calculate the distance between successive coordinates
def calculate_successive_distances(coordinates):
    distances = []
    
    # Iterate over the list of coordinates to calculate the distance between successive points
    for i in range(1, len(coordinates)):
        lat1, lon1 = coordinates[i - 1]
        lat2, lon2 = coordinates[i]
        
        # Calculate the distance between the successive coordinates
        distance = haversine(lat1, lon1, lat2, lon2)
        distances.append((coordinates[i - 1], coordinates[i], distance))
    
    return distances

def calculate_initial_bearing(start, end):
    # Calculate the initial bearing between two points using the Great Circle formula
    lat1, lon1 = math.radians(start[0]), math.radians(start[1])
    lat2, lon2 = math.radians(end[0]), math.radians(end[1])
    
    # Compute the difference in longitude
    dlon = lon2 - lon1
    
    # Compute the initial bearing
    x = math.sin(dlon) * math.cos(lat2)
    y = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dlon)
    initial_bearing = math.atan2(x, y)
    
    # Convert bearing from radians to degrees
    initial_bearing = math.degrees(initial_bearing)
    
    # Normalize the bearing to 0-360 degrees
    if initial_bearing < 0:
        initial_bearing += 360
        
    return initial_bearing

# Function to generate intermediate coordinates
def get_intermediate_coordinates(coords):
    result_coords = []
    
    # Start with the first coordinate as the start point
    for i in range(len(coords) - 1):
        start_point = Point(coords[i][0], coords[i][1])
        end_point = Point(coords[i+1][0], coords[i+1][1])
        
        # Calculate the total distance between the start and end points of this segment
        total_distance = geodesic(start_point, end_point).meters
        
        # Calculate the bearing (direction) between the start and end point using the custom function
        bearing = calculate_initial_bearing((start_point.latitude, start_point.longitude),
                                            (end_point.latitude, end_point.longitude))
        
        # Number of steps to generate (2 meters apart)
        num_steps = int(total_distance // 1)
        
        # Generate the intermediate points (2 meters apart)
        for step in range(1, num_steps + 1):
            # Calculate the destination point after moving 'step' times from the start
            intermediate_point = geodesic(meters=step * 1).destination(start_point, bearing)
            result_coords.append((intermediate_point.latitude, intermediate_point.longitude))
        
        # Append the final coordinate of this segment (the next coordinate)
        result_coords.append((end_point.latitude, end_point.longitude))
    
    return result_coords

intermediate_coords_1 = get_intermediate_coordinates(coordinates_1)
intermediate_coords_2 = get_intermediate_coordinates(coordinates_2)

# Calculate the distances between successive coordinates
successive_distances_1 = calculate_successive_distances(intermediate_coords_1)
successive_distances_2 = calculate_successive_distances(intermediate_coords_2)

# Output the results
# for coord1, coord2, distance in successive_distances_1:
#     if(distance < 0.5):
#         continue
#     print(f"Distance between {coord1} and {coord2}: {distance:.2f} meters")

# for coord1, coord2, distance in successive_distances_2:
#     if(distance < 0.5):
#         continue
#     print(f"Distance between {coord1} and {coord2}: {distance:.2f} meters")


path_data = {}
path_data["path_1"] = [
    coord1 for coord1, _, _ in successive_distances_1
]
path_data["path_2"] = [
    coord1 for coord1, _, _ in successive_distances_2
]

# Save the data to a JSON file
with open('coordinates.json', 'w') as json_file:
    json.dump(path_data, json_file, indent=4)