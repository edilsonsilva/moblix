const route = require("express").Router();
const conexao = require("../database/config.js")



route.post("/insert",(req,res)=>{
    conexao.query(`INSERT INTO turmas SET ?`,req.body,(error,result)=>{
        if(error){
        return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a turma -> ${error}`});
    }
    return res.status(201).send({flag:`OK`,payload:result})
    })
});

route.get("/list",(req,res)  =>{
    conexao.query(`SELECT * FROM turmas`,(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a turma -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_id/:id",(req,res)=>{
    conexao.query(`SELECT * FROM turmas WHERE id=?`,req.params.id,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a turma -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_nivel/:nivel",(req,res)=>{
    conexao.query(`SELECT * FROM turmas WHERE nivel_ensino=?`,req.params.nivel,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a turma -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_turno/:turno",(req,res)=>{
    conexao.query(`SELECT * FROM turmas WHERE turno=?`,req.params.perfil,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a turma -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_ano/:ano",(req,res)=>{
    conexao.query(`SELECT * FROM turmas WHERE ano_letivo=?`,req.params.ano,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a turma -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})
route.put("/update/:id",(req,res)=>{
    conexao.query(`UPDATE turmas SET ? WHERE id = ?`,[req.body, req.params.id],(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao tentar atualizar os dados da turma -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,playload:result})
    })
})

module.exports = route;