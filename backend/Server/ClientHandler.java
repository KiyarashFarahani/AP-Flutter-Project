package backend.Server;

import java.io.*;
import java.net.Socket;

public class ClientHandler implements Runnable {
    private Socket socket;
    private int clientId;
    public  ClientHandler(Socket socket, int clientId){
        this.socket= socket;
        this.clientId= clientId;
    }

    @Override
    public void run() {
    try(BufferedReader in= new BufferedReader(new InputStreamReader(socket.getInputStream()));
        PrintWriter out= new PrintWriter(socket.getOutputStream(), true);
    ){

    } catch (IOException e){
        e.printStackTrace();
    }
    }
}
