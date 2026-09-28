package com.example.le_project;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import java.time.LocalDate;

public class SearchDialogue extends DialogFragment {

    public Button searchButton;
    public EditText editText;
    public ImageButton xButton;

    // actions when new instance is called
    public static SearchDialogue newInstance(String searchJeepney) {
        SearchDialogue fragment = new SearchDialogue();
        Bundle args = new Bundle();
        args.putString("searchJeepney", searchJeepney);
        fragment.setArguments(args);
        return fragment;
    }

    // design when new instance is called
    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        LayoutInflater inflater = getActivity().getLayoutInflater();
        View view = inflater.inflate(R.layout.search, null);

        ClassController.searchedJeep = null;

        editText = view.findViewById(R.id.search_searchbar);

        xButton = view.findViewById(R.id.search_x_button);

        searchButton = view.findViewById(R.id.search_search_button);

        setActionButtons();

        builder.setView(view);
        return builder.create();
    }

    // maps buttons with actions
    public void setActionButtons() {
        searchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // connects to classcontroller with clean text
                ClassController.searchedJeep = editText.getText().toString().toLowerCase().trim();

                // cleans the text
                ClassController.searchedJeep = ClassController.searchedJeep.replaceAll("[^a-z]", "");

                // condtion where text is acceptable
                if(ClassController.searchedJeep != null &&
                        ClassController.searchedJeep.length() >= 4) {
                    toSearchedMainFrame();
                }
                else {
                    Toast.makeText(getContext(), "More Specific", Toast.LENGTH_SHORT).show();
                }
                SearchDialogue.this.getDialog().dismiss()
                ;
            }
        });

        xButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SearchDialogue.this.getDialog().dismiss();
            }
        });
    }
    public void toSearchedMainFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(getActivity(), SearchedMainFrame.class);
                startActivity(intent);
            }
        }, 0);
    }
}
