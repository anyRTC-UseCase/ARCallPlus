package org.ar.call.tools;

import android.util.SparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.IdRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

public class Adapter<T> extends RecyclerView.Adapter<Adapter.Holder> {

  public ArrayList<T> data;
  private final OnBindView<T> onBindView;
  private final OnItemType<T> onItemType;
  private final int[] layoutId;

  public Adapter(ArrayList<T> data, OnBindView<T> onBindView, OnItemType<T> onItemType, int[] layoutId) {
    this.data = data;
    this.onBindView = onBindView;
    this.onItemType = onItemType;
    this.layoutId = layoutId;
  }

  public Adapter(ArrayList<T> data, OnBindView<T> onBindView, int layoutId) {
    this.data = data;
    this.onBindView = onBindView;
    this.onItemType = t -> 0;
    this.layoutId = new int[]{layoutId};
  }

  @NonNull
  @Override
  public Holder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
    LayoutInflater inflater = LayoutInflater.from(parent.getContext());
    return new Holder(inflater.inflate(layoutId[viewType], parent, false));
  }

  @Override
  public int getItemViewType(int position) {
    if (data == null || data.isEmpty())
      return super.getItemViewType(position);

    return onItemType.getItemType(data.get(position));
  }

  @Override
  public void onBindViewHolder(@NonNull Holder holder, int position) {
    onBindView.onBind(holder, data.get(position), position, null);
  }

  @Override
  public void onBindViewHolder(@NonNull Holder holder, int position, @NonNull List<Object> payloads) {
    if (!payloads.isEmpty()) {
      onBindView.onBind(holder, data.get(position), position, payloads);
    } else {
      super.onBindViewHolder(holder, position, payloads);
    }
  }

  @Override
  public int getItemCount() {
    return data.size();
  }

  public static class Holder extends RecyclerView.ViewHolder {

    public Holder(@NonNull View itemView) {
      super(itemView);
    }

    @SuppressWarnings("unchecked")
    public <T extends View> T findView(@IdRes int id) {
      T view;
      if (null == itemView.getTag()) {
        SparseArray<View> sparseArray = new SparseArray<>();
        itemView.setTag(sparseArray);
        view = itemView.findViewById(id);
        sparseArray.put(id, view);
      } else {
        SparseArray<T> sparseArray = (SparseArray<T>) itemView.getTag();
        int key = sparseArray.indexOfKey(id);
        if (key >= 0) {
          view = sparseArray.valueAt(key);
        } else {
          view = itemView.findViewById(id);
          sparseArray.put(id, view);
        }
      }

      return view;
    }
  }

  public interface OnBindView<T> {
    void onBind(Holder holder, T t, int position, @Nullable List<Object> payload);
  }

  public interface OnItemType<T> {
    int getItemType(T t);
  }
}
