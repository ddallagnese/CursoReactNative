package com.dallagnese.kart.Activity;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.dallagnese.kart.Adapters.BateriaAdapter;
import com.dallagnese.kart.Config.ConfiguracaoFirebase;
import com.dallagnese.kart.Models.Bateria;
import com.dallagnese.kart.R;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;

public class BateriaActivity extends AppCompatActivity {

    private String campeonato = "Ligeirinho 2017";
    private DatabaseReference firebase;
    private ListView lvBaterias;
    private ArrayList<Bateria> listaBaterias;
    private ArrayAdapter<Bateria> adapter;
    private ValueEventListener valueEventListenerMensagem;

    @Override
    protected void onStart() {
        super.onStart();
        firebase.addValueEventListener(valueEventListenerMensagem);
    }

    @Override
    protected void onStop() {
        super.onStop();
        firebase.removeEventListener(valueEventListenerMensagem);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_bateria);

        lvBaterias = (ListView) findViewById(R.id.lista_baterias);
        listaBaterias = new ArrayList<>();
        adapter = new BateriaAdapter(BateriaActivity.this, listaBaterias);
        lvBaterias.setAdapter(adapter);

        // Recuperar baterias
        firebase = ConfiguracaoFirebase.getFirebase()
                .child("Campeonatos")
                .child(campeonato)
                .child("Baterias");

        // Cria listener para mensagens entre os usuários definidos
        valueEventListenerMensagem = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                listaBaterias.clear();
                System.out.printf("dados", dataSnapshot);
                for (DataSnapshot dados: dataSnapshot.getChildren()) {
                    listaBaterias.add(dados.getValue(Bateria.class));
                }
                adapter.notifyDataSetChanged();
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {

            }
        };

    }
}
