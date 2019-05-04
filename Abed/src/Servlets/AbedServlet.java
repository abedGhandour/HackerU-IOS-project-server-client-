package Servlets;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.io.IOException;
import java.io.InputStream;

public class AbedServlet extends javax.servlet.http.HttpServlet {
    protected void doPost(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response)
            throws javax.servlet.ServletException, IOException {
        StringBuilder stringBuilder = new StringBuilder();
        byte[] buffer = new byte[2048];
        int actuallyRead;
        InputStream inputStream = request.getInputStream();
        while ((actuallyRead = inputStream.read(buffer)) != -1) {
            stringBuilder.append(new String(buffer, 0, actuallyRead));
        }
        String dataAsString = stringBuilder.toString();
        JSONObject jsonObj = null;
        String value = "";
        JSONArray arrayToSort;
        try {
            jsonObj = new JSONObject(dataAsString);
            value = jsonObj.getString("indexNumber");
            arrayToSort = jsonObj.getJSONArray("sortThis");
            int[] intArray = new int [arrayToSort.length()];
            for (int i = 0; i < intArray.length; ++i) {
                intArray[i] = arrayToSort.optInt(i);
            }
            mergeSort(intArray, 0, intArray.length - 1);
            System.out.println(intArray[Integer.parseInt(value)-1]);
            response.getWriter().write(String.valueOf(intArray[Integer.parseInt(value)-1]));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    protected void doGet(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response)
            throws javax.servlet.ServletException, IOException {
    }
        void merge(int arr[], int l, int m, int r) {
            int n1 = m - l + 1;
            int n2 = r - m;

            int L[] = new int[n1];
            int R[] = new int[n2];

            for (int i = 0; i < n1; ++i)
                L[i] = arr[l + i];
            for (int j = 0; j < n2; ++j)
                R[j] = arr[m + 1 + j];

            int i = 0, j = 0;

            int k = l;
            while (i < n1 && j < n2) {
                if (L[i] <= R[j]) {
                    arr[k] = L[i];
                    i++;
                } else {
                    arr[k] = R[j];
                    j++;
                }
                k++;
            }
            while (i < n1) {
                arr[k] = L[i];
                i++;
                k++;
            }
            while (j < n2) {
                arr[k] = R[j];
                j++;
                k++;
            }
        }
        void sort(int arr[], int l, int r) {
            if (l < r) {
                int m = (l + r) / 2;

                sort(arr, l, m);
                sort(arr, m + 1, r);

                merge(arr, l, m, r);
            }
        }
    void mergeSort(int arr[], int l, int r)
    {
        if (l < r)
        {
            int m = l+(r-l)/2;

            mergeSort(arr, l, m);
            mergeSort(arr, m+1, r);

            merge(arr, l, m, r);
        }
    }
}
