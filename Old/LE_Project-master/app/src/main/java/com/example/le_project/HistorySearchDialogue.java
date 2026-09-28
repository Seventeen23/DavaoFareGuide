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
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

public class HistorySearchDialogue extends DialogFragment {
    public Button searchButton;
    public EditText editText;
    public ImageButton xButton;

    // action when new instance is called
    public static HistorySearchDialogue newInstance(String searchHistory) {
        HistorySearchDialogue fragment = new HistorySearchDialogue();
        Bundle args = new Bundle();
        args.putString("searchHistory", searchHistory);
        fragment.setArguments(args);
        return fragment;
    }

    // design when new instance is called
    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        LayoutInflater inflater = getActivity().getLayoutInflater();
        View view = inflater.inflate(R.layout.searched_history, null);

        ClassController.searchedHistory = null;
        ClassController.isDate = false;
        ClassController.isCategory = false;
        ClassController.isJeepney = false;
        ClassController.isLocation = false;

        editText = view.findViewById(R.id.search_history_searchbar);

        xButton = view.findViewById(R.id.search_history_x_button);

        searchButton = view.findViewById(R.id.search_history_search_button);

        setActionButtons();

        builder.setView(view);
        return builder.create();
    }

    // maps buttons with actions
    public void setActionButtons() {
        searchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // connects to classcontroller with cleaner text
                ClassController.searchedHistory = editText.getText().toString().toLowerCase().trim();

                // cleans the text with regex where / and _ is removed
                ClassController.searchedHistory = ClassController.searchedHistory.replaceAll("[/_]", "-");

                // search conditions
                if(ClassController.searchedHistory != null &&
                        ClassController.searchedHistory.length() >= 4) {
                    toSearchedHistoryFrame();
                }
                else {
                    Toast.makeText(getContext(), "More Specific", Toast.LENGTH_SHORT).show();
                }
                HistorySearchDialogue.this.getDialog().dismiss()
                ;
            }
        });

        xButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                HistorySearchDialogue.this.getDialog().dismiss();
            }
        });
    }
    public void toSearchedHistoryFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(getActivity(), SearchedHistoryFrame.class);
                startActivity(intent);
            }
        }, 0);
    }
}
