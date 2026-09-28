package com.example.le_project;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

public class DBoxDeleteHistory extends DialogFragment {

    public Button yesButton, noButton;
    public ImageButton xButton;

    // action when new instance is called
    public static DBoxDeleteHistory newInstance(String deleteHistory) {
        DBoxDeleteHistory fragment = new DBoxDeleteHistory();
        Bundle args = new Bundle();
        args.putString("deleteHistory", deleteHistory);
        fragment.setArguments(args);
        return fragment;
    }

    // design when instance is called
    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        LayoutInflater inflater = getActivity().getLayoutInflater();
        View view = inflater.inflate(R.layout.dbox_history_delete, null);

        yesButton = view.findViewById(R.id.dbox_history_yes_button);
        noButton = view.findViewById(R.id.dbox_history_no_button);
        xButton = view.findViewById(R.id.dbox_history_x_button);

        setActionButtons();

        builder.setView(view);
        return builder.create();
    }

    // maps buttons with actions
    public void setActionButtons() {
        yesButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // deletes history
                ClassController.HistMap.deleteHistory();

                // sets classcontroller to write the history file
                ClassController.isDelete = true;

                // dismisses the fragment
                toHistoryFrame();
                Toast.makeText(getContext(), "History Deleted", Toast.LENGTH_SHORT).show();
                DBoxDeleteHistory.this.getDialog().dismiss();
            }
        });

        noButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DBoxDeleteHistory.this.getDialog().dismiss();
            }
        });

        xButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DBoxDeleteHistory.this.getDialog().dismiss();
            }
        });
    }

    public void toHistoryFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(getActivity(), SearchedHistoryFrame.class);
                startActivity(intent);
            }
        }, 0);
    }
}
