package com.example.le_project;

import android.app.Activity;
import android.content.Context;
import android.text.Editable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.style.UnderlineSpan;
import android.util.Log;
import android.widget.EditText;

import androidx.appcompat.app.AppCompatActivity;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class ClassController extends Activity {

    // static variables which controls the application
    public static User newUser;
    public static String selectedJeep, searchedJeep, searchedHistory;
    public static HistoryCrud HistMap = new HistoryCrud();
    public static boolean isCategory, isDate, isLocation, isJeepney, isSave, isDelete;

    // list of jeepney options
    public static String[] options = { "ACACIA", "BAGO APLAYA", "BANGKAL", "BANGKAS HEIGHTS", "BARACATAN", "BINUGAO",
            "BUHANGIN via DACUDAO", "BUHANGIN via JP LAUREL AVENUE","BUNAWAN via BUHANGIN", "BUNAWAN via SASA",
            "CABANTIAN", "CALINAN", "CALLAWA", "CATALUNAN GRANDE", "CATIGAN", "CATITIPAN via DACUDAO AVENUE",
            "CATITIPAN via JP LAUREL AVENUE", "COMMUNAL", "COUNTRY HOMES", "DACOVILLE", "DARONG",
            "DONA PILAR via JP LAUREL AVENUE", "ECOLAND SUBDIVISION SM CITY of DAVAO", "EL RIO VISTA", "ELENITA HEIGHTS via MINTAL",
            "EMILY HOMES", "INAWAYAN", "INDANGAN", "JADE VALLEY", "JULIVILLE SUBDIVISION", "LAMANAN", "LANDMARK III",
            "LASANG via BUHANGIN", "LASANG via SASA", "MAA AGDAO", "MAA BANGKEROHAN", "MAHAYAG", "MANDUG", "MANUEL GUIANGA",
            "MARAHAN", "MARILOG", "MATINA APLAYA", "MATINA CROSSING", "MATINA PANGI", "MATINA", "MINTAL", "MULIG", "PANACAN SM CITY ROUTE", "PANACAN via BUHANGIN",
            "PANACAN via CABAGUIO AVENUE","PANACAN via JP LAUREL AVENUE", "ROSALINA I", "ROSALINA III", "SASA via CABAGUIO AVENUE","SASA via JP LAUREL AVENUE", "SASA via R CASTILLO STREET",
            "SIRAWAN", "SURAYA HOMES", "TAGAKPAN", "TALOMO", "TAMUGAN", "TIBULOY TORIL", "TIBUNGCO via BUHANGIN", "TIBUNGO via CABAGUIO AVENUE",
            "TIBUNGCO via R CASTILLO AVENUE", "TIGATTO", "TORIL", "TUGBOK", "ULAS"};

    // initializes the user account
    // must only be called once
    public static void createUser(String email, String fname, String lname, int age, String cat) {
        newUser = new User(email, fname, lname, age, cat);
    }
}
