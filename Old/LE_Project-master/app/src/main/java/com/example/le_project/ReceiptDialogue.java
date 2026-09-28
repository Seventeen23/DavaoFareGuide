package com.example.le_project;

import android.app.AlertDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import java.time.LocalDate;

public class ReceiptDialogue extends DialogFragment {
    public Button recordButton;
    public ImageButton xButton;
    public TextView fromText, toText, jeepText, feeText, kmText;

    // actions when new instance is called
    public static ReceiptDialogue newInstance(String receiptInfo) {
        ReceiptDialogue fragment = new ReceiptDialogue();
        Bundle args = new Bundle();
        args.putString("receipt_info", receiptInfo);
        fragment.setArguments(args);
        return fragment;
    }

    // design when new instance is called
    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        LayoutInflater inflater = getActivity().getLayoutInflater();
        View view = inflater.inflate(R.layout.receipt, null);


        fromText = view.findViewById(R.id.receipt_from_text);
        toText = view.findViewById(R.id.receipt_to_text);
        jeepText = view.findViewById(R.id.receipt_jeepney_text);
        feeText = view.findViewById(R.id.receipt_fee_text);
        kmText = view.findViewById(R.id.receipt_kilomter_text);

        recordButton = view.findViewById(R.id.receipt_save_button);
        xButton = view.findViewById(R.id.receipt_x_button);

        fromText.setText("From\n\t\t" + AlgoHandler.getStartPos().toString());
        toText.setText("To\n\t\t" + AlgoHandler.getEndPos().toString());
        jeepText.setText("Jeepney\n\t\t" + ClassController.selectedJeep.toString());
        feeText.setText("Fee:\t\t\tKilometers");
        kmText.setText(AlgoHandler.getFare() + "\t\t\t\t\t\t" + AlgoHandler.getKM().toString());

        setActionButtons();

        builder.setView(view);
        return builder.create();
    }

    // sets buttons with actions
    public void setActionButtons() {
        recordButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // creates a history record
                ClassController.HistMap.createHistory(new History(AlgoHandler.getId(),
                        LocalDate.now().toString(),
                        ClassController.selectedJeep,
                        AlgoHandler.getStartPos(),
                        AlgoHandler.getEndPos(),
                        AlgoHandler.getKM(),
                        AlgoHandler.getFare()));

                // dismisses the fragment
                Toast.makeText(getContext(), "Recorded", Toast.LENGTH_SHORT).show();
                ReceiptDialogue.this.getDialog().dismiss();
            }
        });

        xButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ReceiptDialogue.this.getDialog().dismiss();
            }
        });
    }
}
