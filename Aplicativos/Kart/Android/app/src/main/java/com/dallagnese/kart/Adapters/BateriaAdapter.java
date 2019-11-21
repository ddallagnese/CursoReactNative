package com.dallagnese.kart.Adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.dallagnese.kart.Models.Bateria;
import com.dallagnese.kart.R;

import java.util.ArrayList;

public class BateriaAdapter extends ArrayAdapter<Bateria> {

    private ArrayList<Bateria> baterias;
    private Context context;

    public BateriaAdapter(Context c, ArrayList<Bateria> objects) {
        super(c, 0, objects);
        this.baterias = objects;
        this.context = c;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = null;

        // Verifica se existem contatos
        if (baterias != null) {
            // Inicializar objeto para montagem da view
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(context.LAYOUT_INFLATER_SERVICE);

            // Monta a view a partir do XML
            view = inflater.inflate(R.layout.bateria_celula, parent, false);
            TextView data = (TextView) view.findViewById(R.id.dataBateria);
            TextView hora = (TextView) view.findViewById(R.id.horaBateria);
            TextView local = (TextView) view.findViewById(R.id.localBateria);
            TextView cidade = (TextView) view.findViewById(R.id.cidadeBateria);
            Bateria bateria = baterias.get(position);
            data.setText(bateria.getData());
            hora.setText(bateria.getHora());
            local.setText(bateria.getLocal());
            cidade.setText(bateria.getCidade());
        }

        return view;
    }
}