package com.example.le_project;

import android.util.Log;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

public class AlgoHandler {

    private static String id, start, end, jeep;
    private static int kmStart, kmEnd;
    private static int n;
    private static double km, temp, fare;
    private static String[][] arr;
    public static HashMap<String, Integer> RouteHashMap = new HashMap<>();

    // algorithm uses the hashmap to calculate the fare
    // designed by Giverphine Dejiga and implemented by Matthew Feri Tanutan
    public static void calculate() {
        km = 0;
        fare = 0;

        kmStart = RouteHashMap.get(start);
        kmEnd = RouteHashMap.get(end);

        Log.i("ALGO", kmStart + "");
        Log.i("ALGO", kmEnd + "");

        if (kmStart < kmEnd) {
            km = kmEnd - kmStart;
        }
        else if (kmStart > kmEnd) {
            km = kmStart - kmEnd;
        }

        temp = km;

        if (temp == 0) {
            fare = 0;
        } else {
            while (true) {

                if (temp > 4) {
                    fare += 1.50;
                    temp--;
                } else if (temp <= 4 && temp > 0) {
                    fare += 13;
                    break;
                }
            }

            // discounts non regular accounts
            if (!ClassController.newUser.getCategory().equals("Regular")) {
                fare -= 2;
            }
        }
    }

    public static ArrayList<String> getStartList() {
        ArrayList<String> keysList = new ArrayList<>(RouteHashMap.keySet());
        Collections.sort(keysList);
        return keysList;
    }

    public static ArrayList<String> getEndList() {
        ArrayList<String> keysList = new ArrayList<>(RouteHashMap.keySet());
        Collections.sort(keysList);
        return keysList;
    }

    public static ArrayList<String> getKMList() {
        ArrayList<String> arrlist = new ArrayList<>();
        int i = 0;
        while (i < n) {
            arrlist.add(arr[i][2]);
            i++;
        }
        return arrlist;
    }

    public static void setStartPos(String startpos) {
        start = startpos;
    }

    public static void setEndPos(String endpos) {
        end = endpos;
    }

    public static void setJeepRoute(String jeeproute) {
        jeep = jeeproute;
    }

    public static String getStartPos() {
        return start;
    }

    public static String getEndPos() {
        return end;
    }

    public static String getKM() {
        return Double.toString(km);
    }

    public static String getFare() {
        return String.format("%.2f", fare);
    }

    public static String getJeepRoute() {
        return jeep;
    }

    public static void setId(String id) {
        id = id;
    }

    public static String getId() {
        return id;
    }
}
