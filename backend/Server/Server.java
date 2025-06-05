package backend.Server;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {
    private final static int PORT= 1234;
    private static int clientCount;
    public static void main(String[] args){
        try(ServerSocket serverSocket= new ServerSocket(PORT);){

            while (!serverSocket.isClosed()){
                Socket socket= serverSocket.accept();
                clientCount++;
                ClientHandler clientHandler= new ClientHandler(socket, clientCount);
                new Thread(clientHandler).start();


            }
        } catch (IOException e){
            e.printStackTrace();
        }
    }
}
