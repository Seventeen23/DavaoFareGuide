package com.example.le_project;

public class User {
    private String email, fname, lname, category;
    private int age;

    public User(String email, String fname, String lname, int age, String category) {
        this.email = email;
        this.fname = fname;
        this.lname = lname;
        this.age = age;
        this.category = category;
    }

    public String getEmail() {
        return email;
    }

    public String getFname() {
        return fname;
    }

    public String getLname() {
        return lname;
    }

    public int getAge() {
        return age;
    }

    public String getCategory() {
        return category;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setFname(String fname) {
        this.fname = fname;
    }

    public void setLname(String lname) {
        this.lname = lname;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public void setCategory(String category) {
        this.category = category;
    }
}
