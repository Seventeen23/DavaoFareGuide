package com.example.le_project;

public class History {

    private String id, date, jeep, start, end, km, fare;

    History(String id, String date, String jeep, String start, String end, String km, String fare) {
        this.id = id;
        this.date = date;
        this.jeep = jeep;
        this.start = start;
        this.end = end;
        this.km = km;
        this.fare = fare;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getId() {
        return id;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public void setJeep(String jeep) {
        this.jeep = jeep;
    }

    public void setStart(String start) {
        this.start = start;
    }

    public void setEnd(String end) {
        this.end = end;
    }

    public void setKM(String km) {
        this.km = km;
    }

    public void setFare(String fare) {
        this.fare = fare;
    }

    public String getDate() {
        return date;
    }

    public String getJeep() {
        return jeep;
    }

    public String getStart() {
        return start;
    }

    public String getEnd() {
        return end;
    }

    public String getKM() {
        return km;
    }

    public String getFare() {
        return fare;
    }

    public String toString() {
        return date + " " + jeep + " " + start + " " +
                end + " " + km + " " + 
                fare;
    }
}
