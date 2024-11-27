import * as fs from 'fs';

// Preload coordinates when the module is imported
let paths: { [key: string]: [number, number][] } = {};

try {
    const data = fs.readFileSync('./coordinates.json', 'utf-8');
    const parsedData = JSON.parse(data);

    // Check if the parsed data contains paths
    if (parsedData && typeof parsedData === 'object') {
        paths = parsedData;
        
        // Validate all paths format (each path should be an array of [lat, lon] pairs)
        Object.keys(paths).forEach(key => {
            if (!Array.isArray(paths[key]) || !paths[key].every(coord => Array.isArray(coord) && coord.length === 2)) {
                throw new Error(`Invalid format for ${key}: coordinates must be an array of [lat, lon] pairs.`);
            }
        });
    } else {
        throw new Error('Invalid structure: coordinates data is missing or incorrect.');
    }
} catch (err) {
    console.error('Error reading or parsing coordinates file:', err);
    paths = {};  // Ensure paths is an empty object in case of an error
}

// Function to calculate the Haversine distance between two coordinates
function haversine(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371000.0;  // Radius of the Earth

    const lat1_rad = lat1 * Math.PI / 180;
    const lon1_rad = lon1 * Math.PI / 180;
    const lat2_rad = lat2 * Math.PI / 180;
    const lon2_rad = lon2 * Math.PI / 180;

    const dlat = lat2_rad - lat1_rad;
    const dlon = lon2_rad - lon1_rad;

    const a = Math.sin(dlat / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon / 2) ** 2;
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
}

// Function to find the nearest coordinate based on the path index (n)
export function findShortestDistance(inputLat: number, inputLon: number, n: number): number | null {
    const pathKey = `path_${n}`;  // Construct the key (e.g., "path_1")

    // Check if the specified path exists
    if (!paths[pathKey]) {
        console.error(`Path "${pathKey}" not found in the coordinates data.`);
        return null;
    }

    const coordinates = paths[pathKey];

    // Find the nearest coordinate
    let minDistance = Infinity;

    for (let coord of coordinates) {
        const [lat, lon] = coord;
        const distance = haversine(inputLat, inputLon, lat, lon);
        if (distance < minDistance) {
            minDistance = distance;
        }
    }

    // If a nearest coordinate is found, return the minimum distance
    return minDistance === Infinity ? null : minDistance;
}
