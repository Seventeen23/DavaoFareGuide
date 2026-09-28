package com.example.le_project;

import java.util.ArrayList;
import java.util.HashMap;

public class HistoryCrud {

    private HashMap<String, History> historyMap;
    private int nextId;

    HistoryCrud() {
        historyMap = new HashMap<>();
    }

    public void createHistory(History h) {
        String newId = generateUniqueID(); 
        h.setId(newId); 
  
        if (!historyMap.containsKey(newId)) {
            historyMap.put(newId, h);
        } else {
            System.out.println("History with ID " + newId + " already exists!");
        }
    }

    private String generateUniqueID() {
       
        String newId = "H" + nextId; 
        nextId++; 
        return newId;
    }
    public HashMap<String, History> getMap() {
        return historyMap;
    }

    public ArrayList<String> getStartList() {
        ArrayList<String> startList = new ArrayList<>();
        for (History history : historyMap.values()) {
            startList.add(history.getStart());
        }
        return startList;
    }

    public void deleteHistory() {
        historyMap.clear();
    }
}