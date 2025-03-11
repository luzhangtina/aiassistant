import { useState, useEffect, useCallback } from 'react';

const sockets: Record<string, WebSocket> = {}; // Stores WebSockets per URL
const socketStatus: Record<string, "connecting" | "connected" | "disconnected"> = {}; // Store connection status per URL

export function useWebSocket(url: string, onMessage: (event: WebSocketMessageEvent) => void) {
  const [status, setStatus] = useState<"connecting" | "connected" | "disconnected">( socketStatus[url] || "connecting" );

  // Setup the WebSocket connection
  useEffect(() => {
    // Only create the WebSocket connection if it doesn't already exist
    if (!sockets[url]) {
        socketStatus[url] = "connecting";
        setStatus("connecting");

        const socket = new WebSocket(url);
        sockets[url] = socket;

        socket.onopen = () => {
            socketStatus[url] = "connected";
            setStatus("connected");
            console.log("WebSocket connected:", url);
        };

        socket.onmessage = (event) => {
            onMessage(event);
        };

        socket.onerror = (error) => {
            console.error("WebSocket error:", error);
            socketStatus[url] = "disconnected";
            setStatus("disconnected");
            delete sockets[url]; // Remove WebSocket instance
        };
    
        socket.onclose = () => {
            console.log("WebSocket closed:", url);
            socketStatus[url] = "disconnected";
            setStatus("disconnected");
            delete sockets[url]; // Remove WebSocket instance
        };
    }

    return () => {
    };
  }, [url]);  // Run only once for each unique URL

  const sendMessage = (msg: object) => {
    if (sockets[url]?.readyState === WebSocket.OPEN) {
      sockets[url].send(JSON.stringify(msg));
    } else {
      console.warn("WebSocket not connected:", url);
    }
  };

  const closeConnection = () => {
    if (sockets[url]) {
      sockets[url].close();
      delete sockets[url];
      delete socketStatus[url];
      setStatus("disconnected");
    }
  };

  return { status, sendMessage, closeConnection };
}
