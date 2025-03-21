import React, { useState } from 'react';

function App() {
  const [role, setRole] = useState(null); // Роль користувача: client, builder, oracle

  return (
    <div className="max-w-4xl mx-auto p-6">
      <h1 className="text-3xl font-bold underline text-center mb-6">
        Construction Escrow MVP
      </h1>

      {!role ? (
        <div className="flex justify-center gap-4">
          <button
            className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
            onClick={() => setRole('client')}
          >
            I am a Client
          </button>
          <button
            className="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600"
            onClick={() => setRole('builder')}
          >
            I am a Builder
          </button>
          <button
            className="bg-purple-500 text-white px-4 py-2 rounded hover:bg-purple-600"
            onClick={() => setRole('oracle')}
          >
            I am an Oracle
          </button>
        </div>
      ) : (
        <div className="text-center">
          <p className="text-xl mb-4">Welcome, {role}!</p>
          {role === 'client' && (
            <div>
              <button className="bg-blue-500 text-white px-4 py-2 rounded">
                Deposit Funds
              </button>
            </div>
          )}
          {role === 'builder' && (
            <div>
              <button className="bg-green-500 text-white px-4 py-2 rounded">
                Submit Proof
              </button>
            </div>
          )}
          {role === 'oracle' && (
            <div>
              <button className="bg-purple-500 text-white px-4 py-2 rounded">
                Confirm Stage
              </button>
            </div>
          )}
          <button
            className="mt-4 text-gray-500 underline"
            onClick={() => setRole(null)}
          >
            Change Role
          </button>
        </div>
      )}
    </div>
  );
}

export default App;