package backend.server;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import backend.utils.JsonDatabase;
import backend.utils.MetadataExtractor;
import backend.model.Song;

public class FileUploadHandler {
	private final String filename;
	private final InputStream clientIn;
	private final long expectedSize;

	public static final String MUSIC_DIR = "data/musics";

	public FileUploadHandler(String filename, InputStream clientIn, long expectedSize) {
		this.filename = filename;
		this.clientIn = clientIn;
		this.expectedSize = expectedSize;
	}

	public boolean receiveFile() {
		try {
			File musicDir = new File(MUSIC_DIR);
			if (!musicDir.exists()) musicDir.mkdirs();


			String finalFilename = filename;
			File file = new File(MUSIC_DIR, finalFilename);

			//rename if already exists
			if (file.exists()) {
				String nameWithoutExt = finalFilename.substring(0, finalFilename.lastIndexOf('.'));
				String extension = finalFilename.substring(finalFilename.lastIndexOf('.'));
				int counter = 1;
				while (file.exists()) {
					finalFilename = nameWithoutExt + "_" + counter + extension;
					file = new File(MUSIC_DIR, finalFilename);
					counter++;
				}
			}

			try (FileOutputStream fos = new FileOutputStream(file)) {
				byte[] buffer = new byte[4096];
				int bytesRead;
				long totalBytesRead = 0;

				System.out.println("Starting to read file data...");
				while (totalBytesRead < expectedSize && (bytesRead = clientIn.read(buffer)) != -1) {
					fos.write(buffer, 0, bytesRead);
					totalBytesRead += bytesRead;
				}

				System.out.println("Finished reading file data. Total bytes read: " + totalBytesRead);

				fos.flush();
				System.out.println("Received file: " + filename + " (" + totalBytesRead + " bytes, expected: " + expectedSize + " bytes)");


				boolean sizeMatches = Math.abs(totalBytesRead - expectedSize) <= 1024;
				if (sizeMatches) {
					System.out.println("File size matches expected size");

					try {
						Song song = MetadataExtractor.extractMetadataFromFile(file);
						if (song != null) {
							Song existingSong = JsonDatabase.findSongByFilename(finalFilename);
							if (existingSong == null) {
								JsonDatabase.addSong(song);
								System.out.println("Song added to database: " + finalFilename);
							} else
								System.out.println("Song already exists in database: " + finalFilename);
						}
					} catch (Exception e) {
						System.err.println("Error extracting metadata or adding to database: " + e.getMessage());
						e.printStackTrace();
					}
				} else {
					System.out.println("File size differs from expected size, but file was saved");
				}

				return sizeMatches;
			}
		} catch (IOException e) {
			System.err.println("Error receiving file: " + e.getMessage());
			e.printStackTrace();
			return false;
		}
	}
}
