#!/usr/bin/env python3
import json

def main():
    with open('assets/data/TR.json', 'r', encoding='utf-8') as f:
        stations = json.load(f)
    
    print(f"Searching for TRT Radyo Haber in {len(stations)} stations...")
    
    # Find TRT Radyo Haber stations
    trt_haber_stations = []
    for i, station in enumerate(stations, 1):
        if 'trt' in station['name'].lower() and 'haber' in station['name'].lower():
            trt_haber_stations.append({
                'position': i,
                'name': station['name'],
                'url': station['url'],
                'votes': station.get('votes', 0),
                'working': station.get('lastcheckok') == 1,
                'uuid': station.get('stationuuid', 'N/A'),
                'favicon': station.get('favicon', '')
            })
    
    if trt_haber_stations:
        print(f"\nFound {len(trt_haber_stations)} TRT Radyo Haber station(s):")
        for station in trt_haber_stations:
            status = "✅ Working" if station['working'] else "❌ NOT Working"
            print(f"\nPosition: {station['position']}")
            print(f"Name: {station['name']}")
            print(f"Status: {status}")
            print(f"Votes: {station['votes']}")
            print(f"URL: {station['url']}")
            print(f"UUID: {station['uuid']}")
            print(f"Favicon: {station['favicon']}")
            
            if station['position'] == 8:
                print("🎯 THIS IS THE 8th STATION!")
    else:
        print("No TRT Radyo Haber stations found.")
    
    # Also check 8th station specifically
    if len(stations) >= 8:
        eighth_station = stations[7]  # 0-indexed
        print(f"\n8th station details:")
        print(f"Name: {eighth_station['name']}")
        print(f"Working: {'✅' if eighth_station.get('lastcheckok') == 1 else '❌'}")
        print(f"URL: {eighth_station['url']}")
        print(f"Votes: {eighth_station.get('votes', 0)}")
        print(f"UUID: {eighth_station.get('stationuuid', 'N/A')}")

if __name__ == "__main__":
    main()